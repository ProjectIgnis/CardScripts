--魔星のウルカ
--Doomstar Ulka
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster that leaves the field OR this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Gain 1500 ATK if it is Special Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp,rp)
	return c:IsMonster() and c:IsPreviousControler(tp) and c:IsFaceup()
		and c:IsReason(REASON_EFFECT) and rp==1-tp
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and s.cfilter(eg:GetFirst(),tp,rp)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (s.spfilter(tc,e,tp) or s.spfilter(c,e,tp)) end
	local loc=LOCATION_REMOVED
	if tc:IsLocation(LOCATION_GRAVE) then loc=loc|LOCATION_GRAVE end
	c:CreateEffectRelation(e)
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then --maybe also add aux.nvfilter(c)?
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	c:ReleaseEffectRelation(e)
	tc:ReleaseEffectRelation(e)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,1500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,2)
		c:RegisterEffect(e1)
	end
end