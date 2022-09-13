--アポクリフォート・キラー
--Apoqliphort Towers
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Requires 3 "Qli" tributes to Normal Summon/Set
	aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	aux.AddNormalSetProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(function(_,c) return not c:IsSetCard(SET_QLI) end)
	c:RegisterEffect(e2)
	--Unaffected by Spell/Traps and monsters with a lower Level/Rank
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) end)
	e3:SetValue(function(e,te) return te:IsActiveType(TYPE_SPELL|TYPE_TRAP) or Qli.ImmunityValue(e,te) end)
	c:RegisterEffect(e3)
	--Special Summoned monsters lose 500 ATK/DEF
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(function(e,c) return c:IsSummonType(SUMMON_TYPE_SPECIAL) end)
	e4:SetValue(-500)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--Make opponent send cards to the GY
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.tgtg)
	e6:SetOperation(s.tgop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_QLI}
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE|LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE|LOCATION_HAND)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsMonster,1-tp,LOCATION_MZONE|LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(sg,true)
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
