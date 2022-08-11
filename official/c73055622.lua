--霊魂の降神
--Shinobird's Calling
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Ritual.AddProcGreater{handler=c,filter=s.ritualfil,extrafil=s.extrafil,extratg=s.extratg}
end
s.fit_monster={25415052,52900000} --should be removed in hardcode overhaul
s.listed_names={25415052,52900000}
function s.ritualfil(c)
	return c:IsCode(25415052,52900000) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:HasLevel() and c:IsType(TYPE_SPIRIT) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end