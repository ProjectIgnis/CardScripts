--ローレ・ライミー
--Lore Leimey
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.setfilter(c)
	return c:IsMonster() and c:IsType(TYPE_EFFECT) and c:IsLevel(3,4) and c:IsAttackBelow(1500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,0,LOCATION_GRAVE,1,1,nil)
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetLabel(g:GetFirst():GetOriginalCodeRule())
		e1:SetValue(s.aclimit)
		e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,1)
		e1:SetTargetRange(1,1)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOriginalCodeRule(e:GetLabel())
end