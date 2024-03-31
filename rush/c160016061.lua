--アビスカイト・レイ・モノクローム
--Abysskite Ray Monochrome
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local atkr=Duel.GetAttacker()
	return atkr and atkr:IsControler(1-tp)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsLevelBelow(4) and c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local lvl=g:Filter(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA):GetSum(Card.GetLevel)
	local tc=Duel.GetAttacker()
	if tc and tc:IsFaceup() and lvl>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lvl*-200)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end