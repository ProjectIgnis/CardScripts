--タマー・ボンド
--Tama Bond
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Treat Level 7 Earth Machines as different names
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetRange(LOCATION_HAND|LOCATION_SZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(_,c)return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(7) end)
	e0:SetValue(CARD_BLUETOOTH_B_DRAGON)
	e0:SetOperation(s.chngcon)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetValue(CARD_REDBOOT_B_DRAGON)
	c:RegisterEffect(e1)
	--Activate
	local e2=Fusion.RegisterSummonEff(c,aux.FilterBoolFunction(s.fusfilter),Fusion.OnFieldMat(Card.IsFaceup),nil,nil,nil,s.stage2)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BLUETOOTH_B_DRAGON,CARD_REDBOOT_B_DRAGON}
function s.chngcon(scard,sumtype,tp)
	return Fusion.SummonEffect and Fusion.SummonEffect:GetHandler():IsCode(id) and ((sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0)
end
function s.fusfilter(c)
	return c:IsRace(RACE_DRAGON|RACE_MACHINE)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk~=1 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end