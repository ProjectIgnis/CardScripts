--天装騎兵スクトゥム
--Armatos Legio Scutum
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--battle protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indval1)
	c:RegisterEffect(e1)
	--effect protection
	local e2=e1:Clone()
	e2:SetValue(s.indval2)
	c:RegisterEffect(e2)
	--cannot select attack, except linked
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
end
function s.indtg(e,c)
	return c:IsLinkMonster() and c:IsSetCard(0x578) and c:IsFaceup() and c:IsControler(e:GetHandler():GetControler())
		and (e:GetHandler():GetLinkedGroup():IsContains(c) or c:GetLinkedGroup():IsContains(e:GetHandler()))
end
function s.indval1(e,re,r,rp)
	if r&REASON_BATTLE~=0 then
		return 1
	else return 0 end
end
function s.indval2(e,re,r,rp)
	if r&REASON_EFFECT~=0 then
		return 1
	else return 0 end
end
function s.atkfilter(c,e)
	return c:IsLinkMonster() and c:IsSetCard(0x578) and c:IsFaceup() and c:IsControler(e:GetHandler():GetControler())
		and (e:GetHandler():GetLinkedGroup():IsContains(c) or c:GetLinkedGroup():IsContains(e:GetHandler()))
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,e)
end
function s.atklimit(e,c)
	return not s.atkfilter(c,e)
end
