--究極融合
--Ultimate Fusion
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.ffilter,matfilter=Card.IsAbleToDeck,
									 extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,stage2=s.desop,extratg=s.extrtarget})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e1)
end
local CARD_BLUEEYES_U_DRAGON=23995346
s.listed_names={CARD_BLUEEYES_W_DRAGON,CARD_BLUEEYES_U_DRAGON}
function s.ffilter(c)
	return c:ListsCodeAsMaterial(CARD_BLUEEYES_W_DRAGON,CARD_BLUEEYES_U_DRAGON)
end
function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil),s.fcheck
end
function s.fcheck(tp,sg,fc,sumtype,tp)
	return sg:IsExists(s.forcedmatfilter,1,nil,fc,sumtype,tp)
end
function s.forcedmatfilter(c,fc,sumtype,tp)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON,CARD_BLUEEYES_U_DRAGON) and c:IsSummonCode(fc,sumtype,tp,fc.material)
end
function s.desfilter(c)
	local code=c:GetPreviousCodeOnField()
	return (code==CARD_BLUEEYES_W_DRAGON or code==CARD_BLUEEYES_U_DRAGON) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.desop(e,tc,tp,mg,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		local mc=mg:FilterCount(s.desfilter,nil)
		if #g>0 and mc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,mc,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
function s.extrtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_ONFIELD)
end