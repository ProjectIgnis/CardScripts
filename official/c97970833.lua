--ラスト・リゾート
--Last Resort
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 "Ancient City - Rainbow Ruins" from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={34487429} --"Ancient City - Rainbow Ruins"
function s.actfilter(c,tp)
	return c:IsCode(34487429) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
	local can_draw=fc and fc:IsFaceup() and Duel.IsPlayerCanDraw(1-tp,1)
	if Duel.ActivateFieldSpell(sc,e,tp,eg,ep,ev,re,r,rp) and can_draw and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end