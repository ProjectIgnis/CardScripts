--始まりの神ファーラ
--Phara, the Goddess of the Beginning
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can reveal this card and 1 Spell/Trap in your hand; neither player can activate cards or effects in response to the card or effect activation of a card with the same name as the revealed Spell/Trap until the end of the next turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.effcost)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--If this card is sent from the hand or field to the GY by Spell/Trap effect: You can Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--If this card is Special Summoned from the GY: You can take control of the 1 monster your opponent controls with the highest ATK (your choice, if tied)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_GRAVE) end)
	e3:SetTarget(s.ctrltg)
	e3:SetOperation(s.ctrlop)
	c:RegisterEffect(e3)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,aux.NOT(Card.IsPublic)),tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSpellTrap,aux.NOT(Card.IsPublic)),tp,LOCATION_HAND,0,1,1,c):GetFirst()
	Duel.ConfirmCards(1-tp,Group.FromCards(c,rc))
	Duel.ShuffleHand(tp)
	e:SetLabel(rc:GetOriginalCodeRule())
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,1,aux.Stringid(id,3),nil,2)
	local revealed_card_code=e:GetLabel()
	--Neither player can activate cards or effects in response to the card or effect activation of a card with the same name as the revealed Spell/Trap until the end of the next turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			local trig_code1,trig_code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
			if trig_code1==revealed_card_code or trig_code2==revealed_card_code then
				return Duel.SetChainLimit(aux.FALSE)
			end
		end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT) and re and re:IsSpellTrapEffect()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	if chk==0 then return g and g:IsExists(Card.IsControlerCanBeChanged,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	if not g or #g==0 then return end
	g:Match(Card.IsControlerCanBeChanged,nil)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		g=g:Select(tp,1,1,nil)
	end
	if #g>0 then
		Duel.HintSelection(g)
		Duel.GetControl(g,tp)
	end
end
