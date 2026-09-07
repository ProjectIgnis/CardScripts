--王家の眠る谷－ネクロバレー
--Necrovalley
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--All "Gravekeeper's" monsters on the field gain 500 ATK/DEF
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1a:SetTarget(function(e,c) return c:IsSetCard(SET_GRAVEKEEPERS) end)
	e1a:SetValue(500)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--Cards in the GY cannot be banished
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_REMOVE)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetTargetRange(LOCATION_GRAVE,0)
	e2a:SetCondition(function(e) return not Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM) end)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetTargetRange(0,LOCATION_GRAVE)
	e2b:SetCondition(function(e) return not Duel.IsPlayerAffectedByEffect(1-e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM) end)
	c:RegisterEffect(e2b)
	--Negate any card effect that would move a card in the GY to a different place. Negate any card effect that changes Types or Attributes in the GY
	local e3a=e2a:Clone()
	e3a:SetCode(EFFECT_NECRO_VALLEY)
	c:RegisterEffect(e3a)
	local e3b=e2b:Clone()
	e3b:SetCode(EFFECT_NECRO_VALLEY)
	c:RegisterEffect(e3b)
	local e3c=e3a:Clone()
	e3c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3c:SetTargetRange(1,0)
	c:RegisterEffect(e3c)
	local e3d=e3b:Clone()
	e3d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3d:SetTargetRange(0,1)
	c:RegisterEffect(e3d)
	--Negate an activated effect when it resolves if it would move a card in the GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
	--Prevent non-activated effects from Special Summoning from the GY (e.g. unclassified summoning effects or delayed effects)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,1)
	e5:SetTarget(s.cannotsptg)
	c:RegisterEffect(e5)
end
s.listed_series={SET_GRAVEKEEPERS}
function s.discheckfilter(c,not_im0,not_im1,re)
	if c:IsControler(0) then return not_im0 and c:IsHasEffect(EFFECT_NECRO_VALLEY) and c:IsRelateToEffect(re)
	else return not_im1 and c:IsHasEffect(EFFECT_NECRO_VALLEY) and c:IsRelateToEffect(re) end
end
function s.discheck(ev,category,re,not_im0,not_im1)
	local ex,tg,ct,p,v=Duel.GetOperationInfo(ev,category)
	if not ex then return false end
	if (category==CATEGORY_LEAVE_GRAVE or v==LOCATION_GRAVE) and ct>0 and not tg then
		if p==0 then return not_im0
		elseif p==1 then return not_im1
		elseif p==PLAYER_ALL then return not_im0 or not_im1
		elseif p==PLAYER_EITHER then return not_im0 and not_im1
		end
	end
	if tg and #tg>0 then
		return tg:IsExists(s.discheckfilter,1,nil,not_im0,not_im1,re)
	end
	return false
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainDisablable(ev) or re:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM) then return end
	local res=false
	local not_im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	local not_im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	if not res and s.discheck(ev,CATEGORY_SPECIAL_SUMMON,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_REMOVE,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOHAND,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TODECK,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOEXTRA,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_EQUIP,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_SET,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_LEAVE_GRAVE,re,not_im0,not_im1) then res=true end
	if res then Duel.NegateEffect(ev) end
end
function s.cannotsptg(e,c,sp,sumtype,sumpos,target_p,sumeff)
	return c:IsLocation(LOCATION_GRAVE) and sumeff and not sumeff:IsActivated() and not sumeff:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE)
		and not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM) and not c:IsHasEffect(EFFECT_NECRO_VALLEY_IM)
		and not sumeff:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM)
end