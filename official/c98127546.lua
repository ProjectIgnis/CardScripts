--閉ザサレシ世界ノ冥神
--Underworld Goddess of the Closed World
--Scripted by DyXel and Edo9300

local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,1)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	--Negate monsters on Link Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(function(e)return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)end)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Unaffected except when targeted
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	--Negate cards&effects that would Special Summon from GY
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.spdiscon)
	e4:SetTarget(s.spdistg)
	e4:SetOperation(function(_,_,_,_,ev)Duel.NegateActivation(ev)end)
	c:RegisterEffect(e4)
end
s.curgroup=nil
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not s.curgroup or #(sg&s.curgroup)<2
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.immval(e,re)
	if not re:IsActivated() or not e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) or e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
function s.spdiscon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or re:GetHandlerPlayer()==tp or
		not Duel.IsChainNegatable(ev) then return false end
	local ex1,tg1,ct1,p1,loc1=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	local ex2,tg2,ct2,p2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	local res1 = ((loc1 or 0)&LOCATION_GRAVE~=0) or (tg1 and tg1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE))
	local res2 = ((loc2 or 0)&LOCATION_GRAVE~=0) or (tg2 and tg2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE))
	return res1 or res2
end
function s.spdistg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
