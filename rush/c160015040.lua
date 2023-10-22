--幻壊溶竜ダークネス・バクハムート
--Demolition Meltdown Dragon Darkness Blasthamut
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160208040,160015010)
	--Send the top 3 cards from the Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,3,1-tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(1-tp,3,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	local ct=og:Filter(Card.IsMonster,nil):GetCount()
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,math.min(#g,ct),nil)
		Duel.HintSelection(sg,true)
		if #sg>0 then
			Duel.BreakEffect()
			local dam=Duel.Destroy(sg,REASON_EFFECT)
			if dam>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,dam*500,REASON_EFFECT)
			end
		end
	end
end