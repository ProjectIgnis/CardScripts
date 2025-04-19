--ダークネス・ネオスフィア
--Darkness Neosphere
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Reveal cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.rvtg)
	e1:SetOperation(s.rvop)
	c:RegisterEffect(e1)
	--Rerrange cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.retg)
	e2:SetOperation(s.reop)
	c:RegisterEffect(e2)
	--Set card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	--Change LP
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.lptg)
	e4:SetOperation(s.lpop)
	c:RegisterEffect(e4)
end
function s.rvtg(e,tp,ev,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_SZONE,0,1,nil) end
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.refilter(c)
	return c:GetFlagEffect(511310100)~=0 and c:GetSequence()<5
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
end
function s.getflag(g,tp)
	local flag = 0
	for c in aux.Next(g) do
		flag = flag|((1<<c:GetSequence())<<(8+(16*c:GetControler())))
	end
	if tp~=0 then
		flag=((flag<<16)&0xffff)|((flag>>16)&0xffff)
	end
	return ~flag
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if #g==0 then return end
	local p
	if g:GetClassCount(Card.GetControler)>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		p=g:Select(tp,1,1,nil):GetFirst():GetControler()
		g=g:Filter(Card.IsControler,nil,p)
	else
		p=g:GetFirst():GetControler()
	end
	local sg=g:Filter(s.setfilter,nil)
	if #sg>0 then
		Duel.SSet(tp,sg)
		Duel.RaiseEvent(sg,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
	g=g:Filter(Card.IsFacedown,nil)
	local filter=s.getflag(g,tp)
	for tc in aux.Next(g) do
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local zone=Duel.SelectFieldZone(tp,1,LOCATION_SZONE,LOCATION_SZONE,filter)
		filter=filter|zone
		local seq=math.log(zone>>8,2)
		local oc=Duel.GetFieldCard(tp,LOCATION_SZONE,seq)
		if oc then
			Duel.SwapSequence(tc,oc)
		else
			Duel.MoveSequence(tc,seq)
		end
	end
end
function s.setfilter(c)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsSSetable(true)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if tc then
		Duel.ChangePosition(tc,POS_FACEDOWN)
		Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)<4000 end
	Duel.SetTargetPlayer(tp)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.SetLP(p,4000)
end