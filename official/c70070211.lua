--ジョウルリ－パンクナシワリ・サプライズ
--Joruri-P.U.N.K. Nashiwari Surprise
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Pop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PUNK}
--Pop
function s.filter(c)
	return c:IsSetCard(SET_PUNK) and c:IsFaceup()
end
function s.tgfilter(c,punk)
	return c:IsFacedown() or punk
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local punk=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc,punk) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,punk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,punk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end