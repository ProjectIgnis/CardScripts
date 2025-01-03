--オオヤツ・ツマムヒメ
--Seed-Spitting Saplings
--Ashaki
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Oyatsu Token"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e2)
	--Negate an opponent's Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep) return ep==1-tp and Duel.GetCurrentChain(true)==0 end)
	e3:SetCost(s.spnegcost)
	e3:SetTarget(s.spnegtg)
	e3:SetOperation(s.spnegop)
	c:RegisterEffect(e3)
end
s.listed_names={id+1} --Oyatsu Token
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT) then return end
	local token=Duel.CreateToken(tp,id+1)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
function s.spnegcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsType,1,false,nil,nil,TYPE_NORMAL) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsType,1,1,false,nil,nil,TYPE_NORMAL)
	Duel.Release(g,REASON_COST)
end
function s.spnegtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.spnegop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end