--デステニー・オーバーレイ
--Destiny Overlay
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and not c:IsType(TYPE_TOKEN)
end
function s.registerxyzmateffect(e,tp)
	local matEff=Effect.CreateEffect(e:GetHandler())
	matEff:SetType(EFFECT_TYPE_FIELD)
	matEff:SetCode(EFFECT_XYZ_MATERIAL)
	matEff:SetTargetRange(0,LOCATION_MZONE)
	Duel.RegisterEffect(matEff,tp)
	return matEff
end
function s.xyzfilter(c,mg,fg,minc,maxg)
	return c:IsXyzSummonable(mg,fg,minc,maxg)
end
function s.rescon(exg)
	return function(sg)
		return exg:IsExists(Card.IsXyzSummonable,1,nil,nil,sg,#sg,#sg)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then
		local matEff=s.registerxyzmateffect(e,tp)
		local res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
		matEff:Reset()
		return res
	end
	local matEff=s.registerxyzmateffect(e,tp)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	local tg=aux.SelectUnselectGroup(mg,e,tp,nil,nil,s.rescon(exg),1,tp,HINTMSG_XMATERIAL,s.rescon(exg))
	matEff:Reset()
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local matEff=s.registerxyzmateffect(e,tp)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,nil,g,#g,#g)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,g,nil,#g,#g)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetOperation(function()
			matEff:Reset()
		end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		xyz:RegisterEffect(e1,true)
	else
		matEff:Reset()
	end
end