--サイバースパイス・カリーパンドラペリー
--Cybersepice Curry Bread Pandora Drapery
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160017019,160017017)
	--Excavate and destroy Spell/Traps
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=4 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(1-tp,4)
	local g=Duel.GetDecktopGroup(1-tp,4)
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if g:FilterCount(Card.IsSpellTrap,nil)>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Destroy(sg,REASON_EFFECT)
	end
	Duel.SortDecktop(1-tp,1-tp,4)
end