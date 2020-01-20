--ガガガカイザー
local s,id=GetID()
function s.initial_effect(c)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	--unsynchroable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--level change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.lvcost)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
function s.atkcon(e)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x54),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.rfilter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
		and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_MZONE,0,1,c,lv)
end
function s.tfilter(c,clv)
	local lv=c:GetLevel()
	return lv>0 and lv~=clv and c:IsFaceup() and c:IsSetCard(0x54)
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	Duel.SetTargetParam(lv)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x54),tp,LOCATION_MZONE,0,nil)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
