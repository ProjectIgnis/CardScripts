--地縛原
--Earthbound Tundra
--Scripted by Larry126
function s.initial_effect(c)
	--cannot summon in def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	--cannot change position
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.poslimit)
	c:RegisterEffect(e4)
	--send
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
	--action card
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(id)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,1)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumpos&POS_DEFENSE>0
end
function s.poslimit(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
function s.disfilter(c)
	return c:IsSetCard(0xac1)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.disfilter,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-ep,LOCATION_HAND)
	Duel.SetChainLimit(s.limit(ep))
end
function s.limit(ep)
	return  function (e,lp,tp)
				return not (e:GetHandler():IsSetCard(0xac1) and tp~=1-ep)
			end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.disfilter,1-ep,LOCATION_HAND,0,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
