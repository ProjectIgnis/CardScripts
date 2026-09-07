--騒動
--Riot's Reason
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 face-down Defense Position monster on the field to the hand, then the player who added it to their hand can Special Summon 1 monster from their hand in face-down Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Change 1 face-down Defense Position monster on the field to Attack Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
function s.rthfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tc:GetOwner(),LOCATION_HAND)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		local sp_player=tc:GetControler()
		Duel.ShuffleHand(sp_player)
		if Duel.GetLocationCount(sp_player,LOCATION_MZONE,sp_player)>0
			and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,sp_player,LOCATION_HAND,0,1,nil,e,0,sp_player,false,false,POS_FACEDOWN_DEFENSE)
			and Duel.SelectYesNo(sp_player,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,sp_player,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(sp_player,Card.IsCanBeSpecialSummoned,sp_player,LOCATION_HAND,0,1,1,nil,e,0,sp_player,false,false,POS_FACEDOWN_DEFENSE)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,sp_player,sp_player,false,false,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
function s.posfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end