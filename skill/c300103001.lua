--Heavy Metal Raiders (Skill)
--Skill activation
--At the start of the Duel, place this card in your Field Zone and flip it over. You draw 1 less card at the beginning of the Duel.
--Effect
--The first time each DARK Machine monster you control would be destroyed by battle each turn, it is not destroyed, and if you took battle damage from the battle, it gains that much ATK after damage calculation, and keeps that ATK gain as long as this card is on the field. Once per turn, if a monster you control that was originally a DARK Machine destroys a card(s) on the field by battle or card effect: You can Special Summon 1 DARK Machine monster from your hand.
local s,id=GetID()
function s.initial_effect(c)
	aux.AddFieldSkillProcedure(c,2,true)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.spcon1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.spcon2)
	c:RegisterEffect(e4)
end
function s.indtg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.indct(e,re,r,rp)
	local c=e:GetHandler()
	if r & REASON_BATTLE ==0 then return 0 end
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local tc=a:GetBattleTarget()
	if tc and tc:IsControler(1-tp) then a,tc=tc,a end
	local dam=Duel.GetBattleDamage(tp)
	if not tc or dam<=0 then return 1 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(dam)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	--Reset
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(function (e)
		if c:GetFlagEffect(id)==0 then
			e1:Reset()
			e:Reset()
		end
	end)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	return 1
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return not tc:IsPreviousControler(tp)
		and bc:IsControler(tp) and bc:GetOriginalAttribute()==ATTRIBUTE_DARK and bc:GetOriginalRace()==RACE_MACHINE
end
function s.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc:IsControler(tp) and rc:GetOriginalAttribute()==ATTRIBUTE_DARK
		and rc:GetOriginalRace()==RACE_MACHINE
		and eg:IsExists(s.cfilter,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
