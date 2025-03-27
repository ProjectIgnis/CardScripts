--王家の眠る谷－ネクロバレー
--Necrovalley
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Increase ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GRAVEKEEPERS))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Cannot banish
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_GRAVE,0)
	e4:SetCondition(s.contp)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetTargetRange(0,LOCATION_GRAVE)
	e5:SetCondition(s.conntp)
	c:RegisterEffect(e5)
	--"Necrovalley" effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_NECRO_VALLEY)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_GRAVE,0)
	e6:SetCondition(s.contp)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetTargetRange(0,LOCATION_GRAVE)
	e7:SetCondition(s.conntp)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_NECRO_VALLEY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(1,0)
	e8:SetCondition(s.contp)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetTargetRange(0,1)
	e9:SetCondition(s.conntp)
	c:RegisterEffect(e9)
	--Negate an effect when it resolves if it would move a card in the GY
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_CHAIN_SOLVING)
	e10:SetRange(LOCATION_FZONE)
	e10:SetOperation(s.disop)
	c:RegisterEffect(e10)
	--Prevent non-activated effects from Special Summoning from the GY (e.g. unclassified summoning effects or delayed effects)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e11:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e11:SetRange(LOCATION_FZONE)
	e11:SetTargetRange(1,1)
	e11:SetTarget(s.cannotsptg)
	c:RegisterEffect(e11)
end
s.listed_series={SET_GRAVEKEEPERS}
function s.contp(e)
	return not Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM)
end
function s.conntp(e)
	return not Duel.IsPlayerAffectedByEffect(1-e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM)
end
function s.disfilter(c,not_im0,not_im1,re)
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
		return tg:IsExists(s.disfilter,1,nil,not_im0,not_im1,re)
	end
	return false
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not Duel.IsChainDisablable(ev) or tc:IsHasEffect(EFFECT_NECRO_VALLEY_IM) then return end
	local res=false
	local not_im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	local not_im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	if not res and s.discheck(ev,CATEGORY_SPECIAL_SUMMON,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_REMOVE,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOHAND,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TODECK,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOEXTRA,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_EQUIP,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_LEAVE_GRAVE,re,not_im0,not_im1) then res=true end
	if res then Duel.NegateEffect(ev) end
end
function s.cannotsptg(e,c,sp,sumtype,sumpos,target_p,sumeff)
	return c:IsLocation(LOCATION_GRAVE) and sumeff and not sumeff:IsActivated() and not sumeff:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE)
		and not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM) and not c:IsHasEffect(EFFECT_NECRO_VALLEY_IM)
		and not sumeff:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM)
end