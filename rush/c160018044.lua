--サイバースパイス・クイーンターメリック
--Cybersepice Queen Turmeric
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160017015,160017013)
	--Excavate the top 3 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(1-tp,3)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if g:FilterCount(Card.IsMonster,nil)>=2 then
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
	Duel.SortDecktop(1-tp,1-tp,3)
end