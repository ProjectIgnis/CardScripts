--魔星のウルカ
--Doomstar Ulka
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 of your monsters that left the field OR this card
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
	--Make this card gain 1500 ATK until the end of the next turn
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
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not (#eg==1 or rp==1-tp) then return false end
	local ec=eg:GetFirst()
	return ec:IsPreviousLocation(LOCATION_MZONE) and ec:IsPreviousControler(tp) and ec:IsReason(REASON_EFFECT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	local sc_chk=ec:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and ec:IsFaceup()
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if sc_chk then
			return ec:IsCanBeSpecialSummoned(e,0,tp,false,false)
		else
			return Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT,1500,400,4,RACE_BEAST,ATTRIBUTE_WIND)
		end
	end
	local c=e:GetHandler()
	local sc=sc_chk and ec or c
	c:CreateEffectRelation(e)
	ec:CreateEffectRelation(e)
	e:SetLabel(sc_chk and 1 or 0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sc,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	local label=e:GetLabel()
	if label==1 then
		if ec:IsRelateToEffect(e) then
			Duel.SpecialSummon(ec,0,tp,tp,false,false,POS_FACEUP)
		elseif c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif label==0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,1500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card gains 1500 ATK until the end of the next turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,2)
		c:RegisterEffect(e1)
	end
end