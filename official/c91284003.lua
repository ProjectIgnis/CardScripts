--ＡＲＧ☆Ｓ－飛燕のカパネ
--Argostars - Swift Capane
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--While this card is face-up in the Spell & Trap Zone, Warrior monsters you control cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsRace(RACE_WARRIOR)
	end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Once per turn, if a Continuous Trap is in a Monster Zone: You can Special Summon this card as an Effect Monster (Warrior/LIGHT/Level 4/ATK 1800/DEF 1800) with the following effect (this card is also still a Trap), then if you have a banished "Argostars" monster, you gain 500 LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsContinuousTrap),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARGOSTARS}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ARGOSTARS,TYPE_MONSTER|TYPE_EFFECT,1800,1800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END&~(RESET_TOFIELD|RESET_LEAVE|RESET_TURN_SET),0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.argosfilter(c)
	return c:IsSetCard(SET_ARGOSTARS) and c:IsMonster() and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ARGOSTARS,TYPE_MONSTER|TYPE_EFFECT,1800,1800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)) then return end
	c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	--● Once per turn (Quick Effect): You can place this card face-up in your Spell & Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:AddMonsterAttributeComplete()
	if Duel.SpecialSummonComplete()>0 and Duel.IsExistingMatchingCard(s.argosfilter,tp,LOCATION_REMOVED,0,1,nil) then
		Duel.BreakEffect()
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end