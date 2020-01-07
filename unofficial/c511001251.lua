--�g�D�[���E�L���O�_��
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(15259703)
	c:RegisterEffect(e2)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.destg)
	e4:SetValue(s.desval)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDecktopGroup(tp,5):IsExists(Card.IsAbleToRemove,5,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetDecktopGroup(tp,5)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function s.dfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)
		and c:IsType(TYPE_TOON) and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(s.dfilter,nil,tp)
		e:SetLabel(count)
		return count>0 and Duel.GetDecktopGroup(tp,count):IsExists(Card.IsAbleToRemove,count,nil)
	end
	return Duel.SelectYesNo(tp,aux.Stringid(43175858,0))
end
function s.desval(e,c)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)
		and c:IsType(TYPE_TOON) and c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_BATTLE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	local g=Duel.GetDecktopGroup(tp,count)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
