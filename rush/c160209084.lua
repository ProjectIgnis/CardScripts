--魔導書棄却
--Spellbook Rejection
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Add excavated monster to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10
end
function s.filter(c)
	return c:IsAbleToGrave() and ((c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)) or c:IsSpell())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	local tg=g:Filter(s.filter,nil)
	if #tg>0 then
		Duel.DisableShuffleCheck()
		local ct=Duel.SendtoGrave(tg,REASON_EFFECT)
		g:RemoveCard(tg)
		Duel.BreakEffect()
		if ct==4 then
			Duel.Draw(tp,1,REASON_EFFECT)
		else
			Duel.ShuffleDeck(tp)
		end
	else
		Duel.ShuffleDeck(tp)
	end
end
