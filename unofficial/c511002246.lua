--ソリッドロイドγ
--Solidroid γ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--There can only be 1 "Solidroid" monster on your field
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x4016),LOCATION_MZONE)
	--Fusion Summon procedure: "Turboroid" + "Strikeroid" + "Stealthroid"
	Fusion.AddProcMix(c,true,true,511002240,511000660,98049038)
	Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.splimit)
	--When this card is Summmoned: Destroy all Set cards your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16304628,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={0x4016} --"Solidroid" archetype
s.material_setcode=SET_ROID
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.contactfilter(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_FUSION|REASON_MATERIAL)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
