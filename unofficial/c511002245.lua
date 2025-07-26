--ソリッドロイドβ
--Solidroid β
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--There can only be 1 "Solidroid" monster on your field
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x4016),LOCATION_MZONE)
	--Fusion Summon procedure:"Stealthroid" + "Turboroid" + "Strikeroid"
	Fusion.AddProcMix(c,true,true,98049038,511002240,511000660)
	Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.splimit)
	--When this card is Summoned: Destroy 1 monster your opponent controls
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
	return Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_FUSION|REASON_MATERIAL)
end
function s.spfilter(c)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
