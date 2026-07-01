--ＡＲＧ☆Ｓ－紫電のテュデル
--Argostars - Lightning Tydeu
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(aux.StatChangeDamageStepCondition)
	e0:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e0)
	--While this card is face-up in the Spell & Trap Zone, Warrior monsters you control gain 500 ATK/DEF
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c)
		return c:IsRace(RACE_WARRIOR)
	end)
	e1a:SetValue(500)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--Once per turn: You can discard 1 card; Special Summon this card as an Effect Monster (Warrior/LIGHT/Level 4/ATK 2000/DEF 2000) with the following effect (this card is also still a Trap), then you can add 1 "Argostars" card from your Deck to your hand, except "Argostars - Lightning Tydeu"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Discard())
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ARGOSTARS}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ARGOSTARS,TYPE_MONSTER|TYPE_EFFECT,2000,2000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END&~(RESET_TOFIELD|RESET_LEAVE|RESET_TURN_SET),0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(SET_ARGOSTARS) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ARGOSTARS,TYPE_MONSTER|TYPE_EFFECT,2000,2000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)) then return end
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
	if Duel.SpecialSummonComplete()==0 then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end