--断影烈破
--Shadow Severing Strike
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Apply 1 of the following effects based on 1 of the card types banished
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return not Duel.IsPhase(PHASE_DAMAGE) end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--Register cards banished
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCode(EVENT_REMOVE)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetLabelObject(e1)
	e1a:SetOperation(s.regop)
	c:RegisterEffect(e1a)
	e1:SetLabelObject(e1a)
	--Add 1 of your other banished cards to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.regfilter(c)
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD) and c:IsReason(REASON_COST)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():CheckCountLimit(tp) then return end
	if not (re and re:IsActivated() and re:IsMonsterEffect()) then return false end
	local og=eg:Filter(s.regfilter,nil)
	if #og>0 then
		local types=0
		for tc in og:Iter() do
			types=types|tc:GetMainCardType()
		end
		local label=e:GetLabel()
		e:SetLabel(label|types)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local types=e:GetLabelObject():GetLabel()>0 and e:GetLabelObject():GetLabel() or e:GetLabel()
	local b1=types&TYPE_MONSTER>0 and Duel.IsExistingMatchingCard(Card.IsNegatableSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b2=types&TYPE_SPELL>0 and Duel.IsPlayerCanDraw(tp,2)
	local b3=types&TYPE_TRAP>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	e:GetLabelObject():SetLabel(0)
	e:SetLabel(types)
	if chk==0 then return (b1 or b2 or b3) end
	local cat=0
	if types&TYPE_MONSTER>0 then
		cat=cat|CATEGORY_DISABLE
		Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
	end
	if types&TYPE_SPELL>0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
	if types&TYPE_TRAP>0 then
		cat=cat|CATEGORY_REMOVE
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
	e:SetCategory(cat)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local types=e:GetLabel()
	local b1=types&TYPE_MONSTER>0 and Duel.IsExistingMatchingCard(Card.IsNegatableSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b2=types&TYPE_SPELL>0 and Duel.IsPlayerCanDraw(tp,2)
	local b3=types&TYPE_TRAP>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if not (b1 or b2 or b3) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	if op==1 then
		--Negate the effects of 1 face-up Spell/Trap on the field until the end of this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local tc=Duel.SelectMatchingCard(tp,Card.IsNegatableSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc)
			tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
		end
	elseif op==2 then
		--Draw 2 cards
		Duel.Draw(tp,2,REASON_EFFECT)
	elseif op==3 then
		--Banish 1 monster on the field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,1,exc)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end