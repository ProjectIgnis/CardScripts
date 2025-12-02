--スカルライズ・スコール
--Skullrise Squall
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={160217001,160018031}
function s.ritualfil(c)
	return c:IsCode(160217001)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_ZOMBIE) and c:IsFaceup()
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if mg:IsExists(Card.IsOriginalCodeRule,1,nil,160018031) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end