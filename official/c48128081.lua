--宿命の決闘
--Destined Duel
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this is activated: Each player can Special Summon 1 monster from their hand in Attack Position, then if there are any other face-up monsters on the field, change all of them to face-down Defense Position. For the rest of this turn after this card resolves, you cannot Normal or Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Once per turn, when your monster declares an attack: You can negate the attack, and if you do, destroy 1 face-down card your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker():IsControler(tp)
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
		if chk==0 then return #g>0 end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.NegateAttack() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end)
	c:RegisterEffect(e2)
	--Once per turn, during your opponent's End Phase: Return this card to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,0)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,POS_FACEDOWN_DEFENSE)
end
function s.spfilter(c,e,sp)
	return c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEUP_ATTACK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
	local turn_player=Duel.GetTurnPlayer()
	local step=turn_player==0 and 1 or -1
	for sp=turn_player,1-turn_player,step do
		if Duel.GetLocationCount(sp,LOCATION_MZONE,sp)>0
			and Duel.IsExistingMatchingCard(s.spfilter,sp,LOCATION_HAND,0,1,nil,e,sp)
			and Duel.SelectYesNo(sp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(sp,s.spfilter,sp,LOCATION_HAND,0,1,1,nil,e,sp):GetFirst()
			if sc then
				sg:AddCard(sc)
				Duel.SpecialSummonStep(sc,0,sp,sp,false,false,POS_FACEUP_ATTACK)
			end
		end
	end
	if Duel.SpecialSummonComplete()>0 and Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,sg) then
		local posg=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,sg)
		Duel.BreakEffect()
		Duel.ChangePosition(posg,POS_FACEDOWN_DEFENSE)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local c=e:GetHandler()
	--For the rest of this turn after this card resolves, you cannot Normal or Special Summon
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,4))
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1a:SetCode(EFFECT_CANNOT_SUMMON)
	e1a:SetTargetRange(1,0)
	e1a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1a,tp)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e1b,tp)
end