--融合複製
--Fusion Reproduction
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FUSION}
function s.cpfilter(c)
	return c:IsSetCard(SET_FUSION) and (c:IsNormalSpell() or c:IsQuickPlaySpell()) and c:IsAbleToRemove()
		and c:CheckActivateEffect(true,true,false)~=nil
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject():GetFirst():CheckActivateEffect(true,true,false)
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil):GetFirst()
	e:SetLabelObject(tc)
	local te=tc:CheckActivateEffect(true,true,false)
	e:SetProperty(EFFECT_FLAG_CARD_TARGET|te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToEffect(e) or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	local te=tc:CheckActivateEffect(true,true,false)
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end