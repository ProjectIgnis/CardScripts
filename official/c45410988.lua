--レッドアイズ・トランスマイグレーション
--Red-Eyes Transmigration
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Ritual.AddProcGreater{handler=c,filter=s.ritualfil,lv=8,extrafil=s.extrafil,extratg=s.extratg}
end
s.listed_series={SET_RED_EYES}
s.fit_monster={19025379} --should be removed in hardcode overhaul
s.listed_names={19025379}
function s.ritualfil(c)
	return c:IsCode(19025379) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),CARD_SPIRIT_ELIMINATION) and c:HasLevel() and c:IsSetCard(SET_RED_EYES)
		and c:IsMonster() and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end