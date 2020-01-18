--天穹覇龍ドラゴアセンション
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
function s.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=#mg
	if chk==0 then return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and mg:FilterCount(s.spfilter,nil,e,tp,c)==ct end
	Duel.SetTargetCard(mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToEffect,nil,e)
	if #g<#mg then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
