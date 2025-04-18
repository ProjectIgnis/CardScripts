--次元融合殺
--Dimension Fusion Destruction
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.RegisterSummonEff{handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_PHANTASM),extrafil=s.fextra,
									chkf=FUSPROC_NOTFUSION|FUSPROC_LISTEDMATS,stage2=s.stage2,extraop=Fusion.BanishMaterial,extratg=s.extratg}
end
s.listed_series={SET_PHANTASM}
s.listed_names={6007213,32491822,69890967}
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler()==e:GetOwner()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6007213,32491822,69890967),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
end