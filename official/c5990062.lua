--大逆転クイズ
--Reversal Quiz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return not c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND|LOCATION_ONFIELD,0)
	g:RemoveCard(e:GetHandler())
	if chk==0 then return #g>0 and not g:IsExists(s.cfilter,1,nil) end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local res=Duel.SelectOption(tp,70,71,72)
	Duel.ConfirmDecktop(tp,1)
	if (res==0 and tc:IsMonster())
		or (res==1 and tc:IsSpell())
		or (res==2 and tc:IsTrap()) then
		local lp1=Duel.GetLP(tp)
		local lp2=Duel.GetLP(1-tp)
		Duel.SetLP(tp,lp2)
		Duel.SetLP(1-tp,lp1)
	end
	Duel.ShuffleDeck(tp)
end