--幻奏の音姫マイスタリン・シューベルト
--Schuberta the Melodious Maestra (anime)
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,76990617,aux.FilterBoolFunctionEx(Card.IsSetCard,0x9b))
	--target grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.material_setcode=0x9b
function s.filter1(c)
	local fc=c:GetReasonCard()
	local fcid
	local fcmc
	if fc then
		if c:GetFlagEffect(id)==0 then
			fcid=fc:GetFieldID()
			fcmc=fc:GetMaterialCount()
			c:RegisterFlagEffect(id,RESET_EVENT+RESET_TOHAND+RESET_TODECK+RESET_REMOVE+RESET_TOFIELD,0,0,fcid)
			c:RegisterFlagEffect(id+1,RESET_EVENT+RESET_TOHAND+RESET_TODECK+RESET_REMOVE+RESET_TOFIELD,0,0,fcmc)
		end
		local i=Duel.GetMatchingGroupCount(s.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,c,c:GetFlagEffectLabel(id))
		if i~=(c:GetFlagEffectLabel(id+1)-1) then
			return false
		end
	else
		return false
	end
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()
		and c:GetReason()&0x40008==0x40008
end
function s.filter2(c,fcid)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()
		and c:GetReason()&0x40008==0x40008
		and c:GetFlagEffectLabel(id)==fcid
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:GetReason()&0x40008==0x40008 and s.filter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local fc=tg:GetFirst():GetFlagEffectLabel(id)
	local i=Duel.GetMatchingGroupCount(s.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,tg,fc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tg1=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,i,i,tg,fc)
	tg:Merge(tg1)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*200)
		c:RegisterEffect(e1)
	end
end