--人造人間－サイコ・ロード
--Jinzo - Lord
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Special Summon this card by sending 1 face-up "Jinzo" you control to the Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	--Trap Cards cannot be activated and the effects of all Trap Cards on the field are negated.
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_CANNOT_TRIGGER)
	e3a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e3a:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e3a)
	--Negate Trap Effects on the field
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD)
	e3b:SetCode(EFFECT_DISABLE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3b:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e3b)
	local e3c=Effect.CreateEffect(c)
	e3c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3c:SetCode(EVENT_CHAIN_SOLVING)
	e3c:SetRange(LOCATION_MZONE)
	e3c:SetOperation(s.disop)
	c:RegisterEffect(e3c)
	--Negate Trap Monsters and their effects
	local e3d=Effect.CreateEffect(c)
	e3d:SetType(EFFECT_TYPE_FIELD)
	e3d:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3d:SetRange(LOCATION_MZONE)
	e3d:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3d:SetTarget(aux.TargetBoolFunction(Card.IsTrap))
	c:RegisterEffect(e3d)
	--Once per turn: You can destroy as many face-up Traps on the field as possible, and if you do, inflict 300 damage to your opponent for each card destroyed.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--Double Snare validity check
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_names={CARD_JINZO}
function s.hspfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_JINZO) and c:IsAbleToGraveAsCost()
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsTrapEffect() then
		Duel.NegateEffect(ev)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#sg*300)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
