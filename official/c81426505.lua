--六武式三段衝
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3d}
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x3d),tp,LOCATION_MZONE,0,3,nil)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) or
		Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_ONFIELD,1,nil) or
		Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil)
	end
	local t={}
	local p=1
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then t[p]=aux.Stringid(id,0) p=p+1 end
	if Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_ONFIELD,1,nil) then t[p]=aux.Stringid(id,1) p=p+1 end
	if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) then t[p]=aux.Stringid(id,2) p=p+1 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sel=Duel.SelectOption(tp,table.unpack(t))+1
	local opt=t[sel]-aux.Stringid(id,0)
	local sg=nil
	if opt==0 then sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	elseif opt==1 then sg=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_ONFIELD,nil)
	else sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_SZONE,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	e:SetLabel(opt)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local sg=nil
	if opt==0 then sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	elseif opt==1 then sg=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_ONFIELD,nil)
	else sg=Duel.GetMatchingGroup(s.filter3,tp,0,LOCATION_SZONE,nil) end
	Duel.Destroy(sg,REASON_EFFECT)
end
