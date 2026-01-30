--アルトメギア・インパスト －奪還－
--Artmage Impact -Recapture-
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you control an "Artmage" monster, you can activate this card the turn it was Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ARTMAGE),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e0)
	--When your opponent activates a monster effect: Banish 1 Fusion Monster you control (until the End Phase), and if you do, negate the activation, and if you do that, destroy that card, then if you have 3 or more different Monster Types on your field, you can return all Spells/Traps your opponent controls to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ARTMAGE}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
end
function s.banfilter(c)
	return c:IsFusionMonster() and c:IsFaceup() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_MZONE,0,1,nil) end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if aux.RemoveUntil(g,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp) and Duel.NegateActivation(ev)
		and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0
		and Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetBinClassCount(Card.GetRace)>=3
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local rg=Duel.GetMatchingGroup(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end