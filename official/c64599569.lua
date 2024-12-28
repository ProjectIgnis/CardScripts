--キメラテック・オーバー・ドラゴン
--Chimeratech Overdragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials: "Cyber Dragon" + 1+ Machine monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),1,99,CARD_CYBER_DRAGON)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--The original ATK/DEF of this card become equal to the number of Fusion Materials used for its Fusion Summon x 800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Send all other cards you control to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
  e3:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.material_setcode={SET_CYBER,SET_CYBER_DRAGON}
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*800)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(c:GetMaterialCount()-1)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e3)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SendtoGrave(g,REASON_EFFECT)
end