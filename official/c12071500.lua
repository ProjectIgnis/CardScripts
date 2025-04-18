--ダーク・コーリング
--Dark Calling
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=s.fusfilter,matfilter=Fusion.InHandMat(Card.IsAbleToRemove),
									extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg,chkf=FUSPROC_NOLIMIT}
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_FUSION}
function s.fusfilter(c)
	return c.dark_calling
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE|LOCATION_HAND,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end