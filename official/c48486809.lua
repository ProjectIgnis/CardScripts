--ハネクリボー ＬＶ６
--Winged Kuriboh LV6
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned with its own procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special Summon Procedure
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Destroy an opponent's monster that declares an attack and inflict damage equal to its original ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e3:SetCost(Cost.SelfTribute)
	e3:SetTarget(s.destg1)
	e3:SetOperation(s.desop1)
	c:RegisterEffect(e3)
	--Destroy an opponent's monster that activates an effect on the field and inflict damage equal to its original ATK
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.descond)
	e4:SetTarget(s.destg2)
	e4:SetOperation(s.desop2)
	c:RegisterEffect(e4)
end
s.listed_names={57116033} --Winged Kuriboh
s.listed_series={SET_ELEMENTAL_HERO,SET_FAVORITE}
function s.spcfilter(c)
	return (c:IsCode(57116033) or (c:IsType(TYPE_FUSION) and c:IsSetCard(SET_ELEMENTAL_HERO)))
		and c:IsMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE,0,e:GetHandler())
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,tp,0)
	if at:GetBaseAttack()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,at:GetBaseAttack())
	end
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if not at:IsRelateToBattle() or Duel.Destroy(at,REASON_EFFECT)==0 then return end
	local atk=at:GetBaseAttack()
	if atk>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_MZONE
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsDestructable() and rc:IsRelateToEffect(re) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,tp,0)
	if rc:GetBaseAttack()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,rc:GetBaseAttack())
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	if not rc:IsRelateToEffect(re) or Duel.Destroy(rc,REASON_EFFECT)==0 then return end
	local atk=rc:GetBaseAttack()
	if atk>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end