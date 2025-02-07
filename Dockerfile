FROM pengchuanzhang/pytorch:ubuntu20.04_torch1.9-cuda11.3-nccl2.9.9

ENTRYPOINT []
RUN apt-get update && apt-get install -y ca-certificates
# install GLIP
RUN mkdir /app/MODEL -p
RUN wget https://penzhanwu2bbs.blob.core.windows.net/data/GLIPv1_Open/models/swin_tiny_patch4_window7_224.pth \
     -qP /app/MODEL/
RUN wget https://penzhanwu2bbs.blob.core.windows.net/data/GLIPv1_Open/models/glip_a_tiny_o365.pth \
     -qP /app/MODEL/

RUN mkdir /root/.cache/huggingface/hub/models--bert-base-uncased/snapshots/0a6aa9128b6194f4f3c4db429b6cb4891cdb421b -p
RUN wget https://huggingface.co/bert-base-uncased/resolve/main/pytorch_model.bin \
     -qP /root/.cache/huggingface/hub/models--bert-base-uncased/snapshots/0a6aa9128b6194f4f3c4db429b6cb4891cdb421b/
RUN wget https://huggingface.co/bert-base-uncased/resolve/main/config.json \
     -qP /root/.cache/huggingface/hub/models--bert-base-uncased/snapshots/0a6aa9128b6194f4f3c4db429b6cb4891cdb421b/
RUN wget https://huggingface.co/bert-base-uncased/resolve/main/tokenizer.json \
     -qP /root/.cache/huggingface/hub/models--bert-base-uncased/snapshots/0a6aa9128b6194f4f3c4db429b6cb4891cdb421b/
RUN wget https://huggingface.co/bert-base-uncased/resolve/main/vocab.txt \
     -qP /root/.cache/huggingface/hub/models--bert-base-uncased/snapshots/0a6aa9128b6194f4f3c4db429b6cb4891cdb421b/
RUN wget https://huggingface.co/bert-base-uncased/resolve/main/tokenizer_config.json \
     -qP /root/.cache/huggingface/hub/models--bert-base-uncased/snapshots/0a6aa9128b6194f4f3c4db429b6cb4891cdb421b/

RUN python -c "import nltk; nltk.download('punkt'); nltk.download('averaged_perceptron_tagger')"
# Change the pip source if needed
# RUN pip config set global.index-url http://mirrors.aliyun.com/pypi/simple
# RUN pip config set install.trusted-host mirrors.aliyun.com
RUN pip install einops shapely timm yacs tensorboardX ftfy prettytable pymongo transformers loralib==0.1.1
COPY ./configs /app/configs
COPY ./knowledge /app/knowledge
COPY ./maskrcnn_benchmark /app/maskrcnn_benchmark
COPY ./odinw /app/odinw
COPY ./setup.py /app/setup.py
COPY ./tools /app/tools
RUN cd /app && python setup.py build develop --user && cd /

# setup ymir & ymir-GLIP
RUN pip install "git+https://github.com/modelai/ymir-executor-sdk.git@ymir2.4.0"

COPY ./ymir /app/ymir
COPY ./start.py /app/start.py
RUN mkdir /img-man && mv /app/ymir/img-man/*.yaml /img-man/

ENV PYTHONPATH=.
WORKDIR /app
RUN echo "python3 /app/start.py" > /usr/bin/start.sh
CMD bash /usr/bin/start.sh
