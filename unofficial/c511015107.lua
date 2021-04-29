--ＤＤＤ シンクロ
--D/D/D Synchro
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x10af}
s.listed_names={47198668}
function s.filter(c,e,tp,rel)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	if not c:IsSetCard(0x10af) then
		return c:IsSynchroSummonable(nil)
	else
		local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,c)
		if c:IsSynchroSummonable(nil,mg) then return true end
		local mc=e:GetHandler()
		if not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and (not rel or mc:IsRelateToEffect(e))) then return false end
		local e1=Effect.CreateEffect(mc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
		e1:SetReset(RESET_CHAIN)
		mc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		e2:SetValue(2)
		mc:RegisterEffect(e2)
		mg:AddCard(mc)
		local res=mg:IsExists(s.ddfilter,1,nil,c,mg,mc)
		e1:Reset()
		e2:Reset()
		return res
	end
end
function s.ddfilter(c,sc,mg,mc)
	return c:IsCode(47198668) and sc:IsSynchroSummonable(Group.FromCards(c,mc),mg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,true)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc:IsSetCard(0x10af) then
			Duel.SynchroSummon(tp,tc,nil)
		else
			local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,tc)
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SYNCHRO_LEVEL)
			e2:SetValue(2)
			c:RegisterEffect(e2)
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsRelateToEffect(e) and (not tc:IsSynchroSummonable(nil,mg) or mg:IsExists(s.ddfilter,1,nil,tc,mg+c,c) and Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
				c:CancelToGrave()
				mg:AddCard(c)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
				local smat=mg:FilterSelect(tp,s.ddfilter,1,1,nil,tc,mg,c)
				Duel.SynchroSummon(tp,tc,smat+c,mg)
			else
				Duel.SynchroSummon(tp,tc,nil,mg)
			end
		end
	end
end
