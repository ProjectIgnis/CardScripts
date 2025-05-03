--キメラテック・クラッシュ・ドラゴン
--Chimeratech Crush Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Cyber Dragon" + 2 or more Machine Type monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),2,99,CARD_CYBER_DRAGON)
	--Monsters you control cannot be destroyed by Spell effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--spsummon success
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.sucop)
	c:RegisterEffect(e2)
end
s.named_material={CARD_CYBER_DRAGON}
function s.efilter(e,te)
	return te:IsSpellEffect()
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Face-up Machine Type monsters on your field gain ATK equal to [the number of monsters used as material for this card's Fusion Summon] x 100.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e1:SetValue(c:GetMaterialCount()*100)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end