--No. 31: Abel's Doom
--No.31 アベルズ・デビル (Anime)
--Fixed By TheOnePharaoh
Duel.LoadCardScript("c95442074.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(id)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--lp set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.lpcon)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	--Destroyed Damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--battle indestructable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(s.indes)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCondition(s.lpcheckcon)
		ge1:SetOperation(s.lpcheckop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={69058960}
s.xyz_number=31
function s.lpcheckcon(e,tp,eg,ev,ep,re,r,rp)
	if s.LP0 and s.LP1 and s.LP0==Duel.GetLP(tp) and s.LP1==Duel.GetLP(1-tp) then
	return false
	end
	return true
end
function s.lpcheckop(e,tp,eg,ev,ep,re,r,rp)
	if not s.LP0 then
	s.LP0=Duel.GetLP(tp)
	end
	if not s.LP1 then
	s.LP1=Duel.GetLP(1-tp)
	end
	if Duel.GetLP(tp)==s.LP0/2 and Duel.GetLP(1-tp)==s.LP1/2 then
	Duel.RaiseEvent(e:GetHandler(),id,e,0,0,0,0)
	end
	s.LP0=Duel.GetLP(tp)
	s.LP1=Duel.GetLP(1-tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(Card.IsCode,tp,0,LOCATION_EXTRA,1,nil,69058960)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	if re:GetHandler()==e:GetHandler() then
	return true
	end
	 return false 
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,1000)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(69058960)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,e:GetHandler():GetAttack(),REASON_EFFECT)
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end