--クリフォート・アクセス
--Qliphort Cephalopod
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	Qli.AddStatChangeEffects(c)
	--Cannot Special Summon monsters, except "Qli" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsSetCard(SET_QLI) end)
	c:RegisterEffect(e1)
	--Opponent monsters lose 300 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
	--Can be Normal Summoned without tributing
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(90)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetCondition(s.ntcon)
	c:RegisterEffect(e3)
	--Unaffected by effects of monsters with lower original Level/Rank
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) end)
	e4:SetValue(Qli.ImmunityValue)
	c:RegisterEffect(e4)
	--Gain LP
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCondition(s.damcon)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
	--Check tribute materials
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(s.trval)
	c:RegisterEffect(e6)
end
s.listed_series={SET_QLI}
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE) and c:GetFlagEffect(id)==0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct1=Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	local ct2=Duel.GetMatchingGroupCount(Card.IsMonster,tp,0,LOCATION_GRAVE,nil)
	local val=(ct2-ct1)*300
	if chk==0 then return val>0 end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	local ct2=Duel.GetMatchingGroupCount(Card.IsMonster,tp,0,LOCATION_GRAVE,nil)
	local val=(ct2-ct1)*300
	if val<=0 then return end
	local dam=Duel.Recover(tp,val,REASON_EFFECT)
	if dam>0 then
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
function s.trval(e,c)
	if c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_QLI) then
		c:RegisterFlagEffect(id,RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end