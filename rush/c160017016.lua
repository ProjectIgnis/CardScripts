--サイバースパイス・クミン
--Cybersepice Cumin
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate and inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(1-tp,1)
	local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if tc:IsMonster() and tc:GetLevel()>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,tc:GetLevel()*100,REASON_EFFECT)
	end
end