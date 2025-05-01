--ＲＵＭ－千死蛮巧 (Anime)
--Rank-Up-Magic Admiration of the Thousands (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER_C}
function s.filter(c,e)
	return c:IsSetCard(SET_NUMBER_C) and c:IsType(TYPE_XYZ) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and (c:GetRank()>0 or c:IsStatus(STATUS_NO_LEVEL)) and c:IsCanBeEffectTarget(e)
end
function s.xyzcheck(c,sg,og,minc,maxc,e)
	if c.rum_limit and not sg:IsExists(c.rum_limit,1,nil,e) then return false end
	local se=nil
	if c.rum_xyzsummon then
		se=c.rum_xyzsummon(c)
	end
	local res=c:IsXyzSummonable(sg,og,minc,maxc)
	if se then
		se:Reset()
	end
	return res
end
function s.rescon(xyzg)
	return function(sg,e,tp,g)
		if xyzg:IsExists(s.xyzcheck,1,nil,nil,sg,#sg,#sg,e) then return true end
		--If no xyz can be summoned using at least the currently seelcted cards as forced materials, stop
		return false,not xyzg:IsExists(s.xyzcheck,1,nil,sg,g,#sg,#g,e)
	end
end
function s.xyzfilter(c,mg,minc,maxc)
	return c:IsSetCard(SET_NUMBER_C) and c:IsXyzSummonable(nil,mg,minc,maxc)
end
function s.register_effects(c,mg,tp)
	local xyz_mat_eff
	if mg:IsExists(Card.IsControler,1,nil,1-tp) then
		xyz_mat_eff=Effect.CreateEffect(c)
		xyz_mat_eff:SetType(EFFECT_TYPE_FIELD)
		xyz_mat_eff:SetCode(EFFECT_XYZ_MATERIAL)
		xyz_mat_eff:SetTargetRange(LOCATION_GRAVE|LOCATION_ONFIELD,LOCATION_GRAVE|LOCATION_ONFIELD)
		xyz_mat_eff:SetTarget(function(e,c) return mg:IsContains(c) end)
		xyz_mat_eff:SetReset(RESETS_STANDARD)
		xyz_mat_eff:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
		Duel.RegisterEffect(xyz_mat_eff,tp)
	end
	local xyz_level_eff=Effect.CreateEffect(c)
	xyz_level_eff:SetType(EFFECT_TYPE_FIELD)
	xyz_level_eff:SetCode(EFFECT_XYZ_LEVEL)
	xyz_level_eff:SetTargetRange(LOCATION_GRAVE|LOCATION_ONFIELD,LOCATION_GRAVE|LOCATION_ONFIELD)
	xyz_level_eff:SetTarget(function(e,c) return mg:IsContains(c) end)
	xyz_level_eff:SetReset(RESETS_STANDARD)
	xyz_level_eff:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	xyz_level_eff:SetValue(function(e,c) if a then Debug.Message("b") end return c:GetRank()+1 end)
	Duel.RegisterEffect(xyz_level_eff,tp)
	return xyz_mat_eff,xyz_level_eff
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,LOCATION_GRAVE|LOCATION_ONFIELD,nil,e)
	local xyz_mat_eff,xyz_level_eff=s.register_effects(e:GetHandler(),mg,tp)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if chk==0 then
		xyz_level_eff:Reset()
		if xyz_mat_eff then xyz_mat_eff:Reset() end
		return #xyzg>0
	end
	local sg=aux.SelectUnselectGroup(mg,e,tp,1,#mg,s.rescon(xyzg),1,tp,HINTMSG_TARGET,s.rescon(xyzg))
	Duel.SetTargetCard(sg)
	xyz_level_eff:Reset()
	if xyz_mat_eff then xyz_mat_eff:Reset() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetTargetCards(e)
	local c=e:GetHandler()
	local xyz_mat_eff,xyz_level_eff=s.register_effects(c,mg,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg,#mg,#mg):GetFirst()
	if xyz then
		mg:KeepAlive()
		aux.RankUpComplete(xyz,aux.Stringid(id,1))
		Duel.XyzSummon(tp,xyz,mg,mg,#mg,#mg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetOperation(function()
			xyz_level_eff:Reset()
			if xyz_mat_eff then xyz_mat_eff:Reset() end
			mg:DeleteGroup()
		end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		xyz:RegisterEffect(e1,true)
	else
		xyz_level_eff:Reset()
		if xyz_mat_eff then xyz_mat_eff:Reset() end
	end
end
