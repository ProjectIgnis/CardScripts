--ジョインテック・エースレックス
--Jointech Ace Rex
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials: "Jointech Rex" + "Jointech Ace"
	Fusion.AddProcMix(c,true,true,160312010,160009019)
	--Destroy 1 Spell/Trap Card on the field. Then, this card can attack twice this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_GRAVE,0,1,nil) end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local cg=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_GRAVE,0,1,1,nil)
	if #cg==0 then return end
	Duel.HintSelection(cg,true)
	if Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		if Duel.Destroy(dg,REASON_EFFECT)>0 then
			--This card can attack twice this turn
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3201)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end